.PHONY: doc

doc:
	./bin/extract_section.sh ./build/configuration.txt 'OVERWRITEABLE CONFIGURATION' lua/nighthawk/config.lua
	cp ./etc/sections/installation.txt ./build/installation.txt
	./bin/replace_section.sh ./build/installation.txt 'CONFIGURATION' ./build/configuration.txt

	cp ./etc/frames/nighthawk.vim.txt ./build/nighthawk.txt
	./bin/replace_section.sh ./build/nighthawk.txt 'INTRODUCTION' ./etc/sections/introduction.txt
	./bin/replace_section.sh ./build/nighthawk.txt 'FUNCTIONALITY' ./etc/sections/functionality.txt
	./bin/replace_section.sh ./build/nighthawk.txt 'INSTALLATION' ./build/installation.txt
	./bin/replace_section.sh ./build/nighthawk.txt 'DOCUMENTATION' ./etc/sections/documentation.txt
	./bin/replace_section.sh ./build/nighthawk.txt 'LICENSE' ./etc/sections/license.txt
	./bin/replace_keyword.sh ./build/nighthawk.txt 'VERSION' '0.1'
	cp ./build/nighthawk.txt ./doc/nighthawk.txt
	
	cp ./etc/frames/readme.md.txt ./build/README.md
	./bin/replace_section.sh ./build/README.md INTRODUCTION ./etc/sections/introduction.txt
	./bin/replace_section.sh ./build/README.md FUNCTIONALITY ./etc/sections/functionality.txt
	./bin/replace_section.sh ./build/README.md INSTALLATION ./build/installation.txt
	./bin/replace_section.sh ./build/README.md DOCUMENTATION ./etc/sections/documentation.txt
	./bin/replace_section.sh ./build/README.md LICENSE ./etc/sections/license.txt
	cp ./build/README.md ./README.txt
	
	cp ./etc/frames/license.txt ./LICENSE
	./bin/replace_section.sh ./LICENSE LICENSE ./etc/sections/license.txt

all: doc

clean:
	rm ./build/*
