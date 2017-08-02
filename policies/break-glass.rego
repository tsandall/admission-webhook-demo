package kubernetes

# This sets a value for "data.kubernetes.break_glass" in OPA
#
# In the other policy, the blacklist will only be hit IF
# "data.kubernetes.break_glass" is not set/undefined.
break_glass = true
