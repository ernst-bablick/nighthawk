.PHONY: doc

doc:
	cp ./etc/frames/nighthawk.vim.txt ./doc/nighthawk.txt 
	./bin/replace_section.sh ./doc/nighthawk.txt INTRODUCTION ./etc/sections/introduction.txt
	./bin/replace_section.sh ./doc/nighthawk.txt FUNCTIONALITY ./etc/sections/functionality.txt
	./bin/replace_section.sh ./doc/nighthawk.txt INSTALLATION ./etc/sections/installation.txt
	./bin/replace_section.sh ./doc/nighthawk.txt DOCUMENTATION ./etc/sections/documentation.txt
	./bin/replace_section.sh ./doc/nighthawk.txt LICENSE ./etc/sections/license.txt
	
	cp ./etc/frames/readme.md.txt ./README.md
	./bin/replace_section.sh ./README.md INTRODUCTION ./etc/sections/introduction.txt
	./bin/replace_section.sh ./README.md FUNCTIONALITY ./etc/sections/functionality.txt
	./bin/replace_section.sh ./README.md INSTALLATION ./etc/sections/installation.txt
	./bin/replace_section.sh ./README.md DOCUMENTATION ./etc/sections/documentation.txt
	./bin/replace_section.sh ./README.md LICENSE ./etc/sections/license.txt
	
	cp ./etc/frames/license.txt ./LICENSE
	./bin/replace_section.sh ./LICENSE LICENSE ./etc/sections/license.txt
	
all: doc
