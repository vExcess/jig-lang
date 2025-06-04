build:
	zig build-exe -freference-trace -O ReleaseFast -target x86_64-linux-gnu --name native-out src/demo.zig

dev:
	zig run ./src/demo.zig

wasm:
	zig build-exe -fno-entry -rdynamic -freference-trace -O ReleaseSmall -target wasm32-freestanding --name wasm-out src/wasm-demo.zig