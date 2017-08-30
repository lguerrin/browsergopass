package main

import "testing"

func TestUsernameFromKey(t *testing.T) {
	value := UsernameFromKey("/test/sub/username")
	if value != "username" {
		t.Fail()
	}
}

func TestRootDomain(t *testing.T) {
	value := RootDomain("domain.fr")
	if value != "domain.fr" {
		t.Fail()
	}

	value = RootDomain("sub.domain.fr")
	if value != "domain.fr" {
		t.Fail()
	}
}

