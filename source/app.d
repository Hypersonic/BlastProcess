import std.stdio;

import gfm.sdl2;

import state;

void main()
{
	auto width  = 1000;
	auto height = 1000;

	State state;
	state.sdl2 = new SDL2(null);
	auto window = new SDL2Window(state.sdl2,
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		width, height,
		SDL_WINDOW_SHOWN);
	state.renderer = new SDL2Renderer(window);

	// state loop
	while (state.running) {
		state.sdl2.processEvents();

		checkKeys(state);
	}

	// ciao!
	writeln("quitting; goodbye");
}

void checkKeys(ref State state) {
	if (state.sdl2.keyboard().isPressed(SDLK_q))
		state.running = false;
}
