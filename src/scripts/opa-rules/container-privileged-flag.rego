package kubernetes.validating.privileged

deny[msg] {
	some c
	input_container[c]
	c.securityContext.privileged
	msg := sprintf("Container '%v' should not run in privileged mode.", [c.name])
}

input_container[container] {
	container := input.spec.template.spec.containers[_]
}

input_container[container] {
	container := input.spec.template.spec.initContainers[_]
}