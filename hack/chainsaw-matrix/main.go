package main

import (
	"fmt"
	"path/filepath"
	"slices"
	"strings"

	"github.com/kyverno/chainsaw/pkg/discovery"
)

const max = 12

func main() {
	tests, err := discovery.DiscoverTests("chainsaw-test.yaml", nil, false, "../..")
	if err != nil {
		panic(err)
	}
	var paths []string
	for _, test := range tests {
		path, err := filepath.Rel("../..", test.BasePath)
		if err != nil {
			panic(err)
		}
		parts := strings.Split(path, "/")
		if len(parts) < 3 {
			panic("not enough folder parts: " + path)
		}
		if strings.HasSuffix(parts[0], "-cel") {
			continue
		}
		parts = parts[:len(parts)-1]
		paths = append(paths, strings.Join(parts, "/"))
	}
	slices.Sort(paths)
	root := ""
	var entries []string
	flush := func() {
		if len(entries) != 0 {
			pattern := ""
			for _, part := range strings.Split(root, "/") {
				pattern += "^" + part + "$" + "/"
			}
			pattern += "^" + "(" + strings.Join(entries, "|") + ")" + "$"
			fmt.Println("- " + pattern)
			entries = nil
		}
	}
	for _, path := range paths {
		parts := strings.Split(path, "/")
		parent := strings.Join(parts[:len(parts)-1], "/")
		if parent != root {
			flush()
		} else if len(entries) > max {
			flush()
		}
		root = parent
		entries = append(entries, parts[len(parts)-1])
	}
	flush()
}
