package main

import (
	"bytes"
	"os/exec"
	"fmt"
	"strings"
	"os"
	"io"
	"encoding/binary"
	"encoding/json"
	"path/filepath"
)

var endianness = binary.LittleEndian
var gopass = "/usr/local/bin/gopass"

// msg defines a message sent from a browser extension.
type msg struct {
	Action string `json:"action"`
	Domain string `json:"domain"`
	Entry  string `json:"entry"`
}

// Credentials represents a single pass login.
type Credentials struct {
	Username string `json:"u"`
	Password string `json:"p"`
}

func main() {
	if err := Run(os.Stdin, os.Stdout); err != nil && err != io.EOF {
		LogDebug(ToJson(err))
	}
}

func Run(stdin io.Reader, stdout io.Writer) error {

	// Get message length, 4 bytes
	var n uint32
	if err := binary.Read(stdin, endianness, &n); err == io.EOF {
		return nil
	} else if err != nil {
		return err
	}

	// Get message body
	var data msg
	lr := &io.LimitedReader{R: stdin, N: int64(n)}
	if err := json.NewDecoder(lr).Decode(&data); err != nil {
		return err
	}
	var resp interface{}
	var err error

	LogDebug("msg:" + ToJson(data))
	switch data.Action {
	case "search":
		resp, err = search(data.Domain)
	case "get":
		resp, err = readLogin(data.Entry)
	}

	if err != nil {
		return err
	}

	var b bytes.Buffer
	if err := json.NewEncoder(&b).Encode(resp); err != nil {
		return err
	}

	if err := binary.Write(stdout, endianness, uint32(b.Len())); err != nil {
		return err
	}
	if _, err := b.WriteTo(stdout); err != nil {
		return err
	}

	return nil

}

func search(domain string) ([]string, error) {
	search := exec.Command(gopass, "search", domain)
	var out bytes.Buffer
	search.Stdout = &out
	err := search.Run()
	if err != nil {
		return nil, err
	}

	return delete_empty(strings.Split(out.String(), "\n")), nil
}

func readLogin(key string) (*Credentials, error) {

	password := exec.Command(gopass, key)
	var out bytes.Buffer
	var stderr bytes.Buffer
	password.Stdout = &out
	password.Stderr = &stderr
	var credentials = new(Credentials)

	err := password.Run()
	if err != nil {
		LogDebug("Error during retrieving password:" + stderr.String())
		return nil, err
	}
	pass := strings.TrimSpace(out.String())
	credentials.Password = pass
	credentials.Username = UsernameFromKey(key)
	LogDebug("Credentials: " + ToJson(credentials))
	return credentials, nil
}

func delete_empty(s []string) []string {
	var r []string
	for _, str := range s {
		if str != "" {
			r = append(r, str)
		}
	}
	return r
}

func LogDebug(msg string) {
	fmt.Fprintln(os.Stderr, msg)
}

func ToJson(obj interface{}) string {
	b, err := json.Marshal(obj)
	if err != nil {
		panic(err)
	}
	return string(b)
}

func UsernameFromKey(name string) string {
	if strings.Count(name, "/") >= 1 {
		return filepath.Base(name)
	}
	return ""
}
