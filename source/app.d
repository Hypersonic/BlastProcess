import std.stdio;

import gfm.sdl2;

import state;

void main()
{
	State state = new State;
	state.sdl2 = new SDL2(null);
	auto window = new SDL2Window(state.sdl2,
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		state.width, state.height,
		SDL_WINDOW_SHOWN);
	state.renderer = new SDL2Renderer(window);

	// state loop
	while (state.running) {
		state.sdl2.processEvents();

		checkKeys(state);
		update(state);
		render(state);
	}

	// ciao!
	writeln("quitting; goodbye");
}

void checkKeys(ref State state) {
	if (state.sdl2.keyboard().isPressed(SDLK_q))
		state.running = false;
}

void update(ref State state) {
}

void render(ref State state) {
	auto renderer = state.renderer;
	renderer.setColor(0, 0, 0);
	renderer.clear();

	renderer.setColor(200, 200, 200);
	renderer.fillRect(10, 10, 10, 10);
	renderer.present();
}
