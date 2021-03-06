package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	"github.com/tsandall/admission-webhook-demo/admissionv1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	admissionregistrationv1 "k8s.io/client-go/pkg/apis/admissionregistration/v1alpha1"
	"k8s.io/client-go/rest"
)

func main() {

	config, err := rest.InClusterConfig()
	if err != nil {
		log.Fatalf("Failed to load kubeconfig: %v", err)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatalf("Failed to load client: %v", err)
	}

	caCert, err := ioutil.ReadFile("/certs/ca/ca.crt")
	if err != nil {
		log.Fatalf("Failed to load CA certificate; %v", err)
	}

	serverCert, err := tls.LoadX509KeyPair("/certs/server/tls.crt", "/certs/server/tls.key")
	if err != nil {
		log.Fatalf("Failed to load server TLS keypair: %v", err)
	}

	if err := register(clientset, caCert, "admission-webhook-demo"); err != nil {
		log.Fatalf("Failed to register webhook: %v", err)
	}

	clientCA := x509.NewCertPool()
	clientCA.AppendCertsFromPEM(caCert)

	c := &controller{clientset}

	http.HandleFunc("/", c.Serve)

	server := &http.Server{
		Addr: ":8000",
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{serverCert},
			ClientCAs:    clientCA,
			ClientAuth:   tls.RequireAndVerifyClientCert,
		},
	}

	server.ListenAndServeTLS("", "")
}

func register(clientset *kubernetes.Clientset, caCert []byte, webhookName string) error {

	client := clientset.AdmissionregistrationV1alpha1().ExternalAdmissionHookConfigurations()
	_, err := client.Get(webhookName, metav1.GetOptions{})
	if err == nil {
		if err := client.Delete(webhookName, nil); err != nil {
			return err
		}
	}

	for {
		time.Sleep(1 * time.Second)
		webhookConfig := &admissionregistrationv1.ExternalAdmissionHookConfiguration{
			ObjectMeta: metav1.ObjectMeta{
				Name: webhookName,
			},
			ExternalAdmissionHooks: []admissionregistrationv1.ExternalAdmissionHook{
				{
					Name: webhookName + ".tsandall.github.com",
					Rules: []admissionregistrationv1.RuleWithOperations{{
						Operations: []admissionregistrationv1.OperationType{admissionregistrationv1.OperationAll},
						Rule: admissionregistrationv1.Rule{
							APIGroups:   []string{""},
							APIVersions: []string{"v1"},
							Resources:   []string{"pods/*"},
						},
					}},
					ClientConfig: admissionregistrationv1.AdmissionHookClientConfig{
						Service: admissionregistrationv1.ServiceReference{
							Namespace: "default",
							Name:      webhookName,
						},
						CABundle: caCert,
					},
				},
			},
		}
		if _, err := client.Create(webhookConfig); err != nil {
			log.Printf("Failed to install webhook configuration: %v", err)
		} else {
			log.Printf("Installed webhook configuration")
			return nil
		}
	}
}

var allowed = admissionv1.AdmissionReviewStatus{
	Allowed: true,
}

var denied = admissionv1.AdmissionReviewStatus{
	Allowed: false,
	Result: &metav1.Status{
		Message: "exec into privileged pod disallowed by alice's policy",
	},
}

type controller struct {
	clientset *kubernetes.Clientset
}

func (c *controller) Admit(review admissionv1.AdmissionReview) (admissionv1.AdmissionReviewStatus, error) {

	if review.Spec.Operation != "CONNECT" || review.Spec.SubResource != "exec" {
		return allowed, nil
	}

	if review.Spec.Namespace != "production" {
		return allowed, nil
	}

	pod, err := c.clientset.CoreV1().Pods(review.Spec.Namespace).Get(review.Spec.Name, metav1.GetOptions{})
	if err != nil {
		return allowed, err
	}

	for _, container := range pod.Spec.Containers {
		if container.SecurityContext.Privileged != nil && *container.SecurityContext.Privileged {
			log.Printf("Denying exec into %v because %v is privileged", review.Spec.Name, container.Name)
			return denied, nil
		}
	}

	return allowed, nil
}

func (c *controller) Serve(w http.ResponseWriter, r *http.Request) {

	var body []byte
	if r.Body != nil {
		if data, err := ioutil.ReadAll(r.Body); err == nil {
			body = data
		}
	}

	contentType := r.Header.Get("Content-Type")
	if contentType != "application/json" {
		serveError(w, http.StatusBadRequest, "invalid content-type")
		return
	}

	var review admissionv1.AdmissionReview

	if err := json.Unmarshal(body, &review); err != nil {
		serveError(w, http.StatusBadRequest, "invalid body")
		return
	}

	status, err := c.Admit(review)
	if err != nil {
		serveError(w, http.StatusInternalServerError, err.Error())
		return
	}

	review.Status = status

	bs, err := json.Marshal(review)
	if err != nil {
		serveError(w, http.StatusInternalServerError, err.Error())
		return
	}

	_, err = w.Write(bs)
	if err != nil {
		log.Printf("Failed to write admission response: %v", err)
	}

}

func serveError(w http.ResponseWriter, status int, msg string) {
	w.WriteHeader(status)
	w.Write([]byte(msg))
}
