package main

import (
	"fmt"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"text/template"

	"github.com/kyverno/chainsaw/pkg/discovery"
)

const chunkSize = 12

type testSuite struct {
	Name     string
	Pattern  string
	Folder   string
	Required bool
}

type values struct {
	TestSuites []testSuite
}

type payload struct {
	Values values
}

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
	suites := map[string][]string{}
	for _, path := range paths {
		parts := strings.Split(path, "/")
		root := strings.Join(parts[:len(parts)-1], "/")
		suites[root] = append(suites[root], parts[len(parts)-1])
	}
	var ts []testSuite
	for _, key := range slices.Sorted(maps.Keys(suites)) {
		root := ""
		for _, part := range strings.Split(key, "/") {
			root += "^" + part + "$" + "/"
		}
		slices.Sort(suites[key])
		for i := 0; i < len(suites[key]); i += chunkSize {
			end := i + chunkSize
			if end > len(suites[key]) {
				end = len(suites[key])
			}
			pattern := root + "^" + "(" + strings.Join(suites[key][i:end], "|") + ")" + "$"
			name := strings.ReplaceAll(key, "/", "_")
			if i >= chunkSize {
				name = fmt.Sprintf("%s-%d", name, i)
			}
			ts = append(ts, testSuite{
				Required: true,
				Name:     name,
				Folder:   key,
				Pattern:  pattern,
			})
		}
	}
	var tmplFile = "workflow.yaml"
	tmpl, err := template.New(tmplFile).ParseFiles(tmplFile)
	if err != nil {
		panic(err)
	}
	err = tmpl.Execute(os.Stdout, payload{
		Values: values{
			TestSuites: ts,
		},
	})
	if err != nil {
		panic(err)
	}
}
