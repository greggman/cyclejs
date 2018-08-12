BUMP=.scripts/bump.js

ARG=$(filter-out $@,$(MAKECMDGOALS))

help :
	@echo "Available commands in the Cycle.js monorepo:"
	@echo ""
	@echo "  make release-minor <package>\trelease a new minor version of <package>"
	@echo "  make release-major <package>\trelease a new major version of <package>"
	@echo ""

prebump :
	pnpm recursive test --filter @cycle/$(ARG)

postbump :
	make docs $(ARG)
	cd $(ARG) && pnpm run changelog && cd ..
	git add -A
	git commit -m "release($(ARG)): $(shell cat $(ARG)/package.json | $(JASE) version)"
	git push origin master
	cd $(ARG) ; pnpm publish ; cd ..

release-minor :
	@if [ "$(ARG)" = "" ]; then \
		echo "Error: please call 'make release-minor' with an argument, like 'make release-minor dom'" ;\
	else \
		make prebump $(ARG) ;\
		$(BUMP) $(ARG)/package.json --minor ;\
		make postbump $(ARG) ;\
		echo "✓ Released new minor for $(ARG)" ;\
	fi

release-major :
	@if [ "$(ARG)" = "" ]; then \
		echo "Error: please call 'make release-major' with an argument, like 'make release-major dom'" ;\
	else \
		make prebump $(ARG) ;\
		$(BUMP) $(ARG)/package.json --major ;\
		make postbump $(ARG) ;\
		echo "✓ Released new major for $(ARG)" ;\
	fi
