import std.stdio;
import std.random;

import gfm.sdl2;

import state;

void main()
{
	State state = new State;
	init(state);

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

void init(ref State state) {
	state.sdl2 = new SDL2(null);
	auto window = new SDL2Window(state.sdl2,
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		state.width, state.height,
		SDL_WINDOW_SHOWN);
	state.renderer = new SDL2Renderer(window);

	for (int i = 0; i < 40; i++) {
		int lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(175 + (1/12. + lane / 6.) * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
		lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(575 + (1/12. + lane / 6.) * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
	}
}

void update(ref State state) {
}

void render(ref State state) {
	auto renderer = state.renderer;
	renderer.setColor(0, 0, 0);
	renderer.clear();

	// roads ???
	renderer.setColor(80, 80, 80);
	renderer.fillRect(175, 0, state.laneWidth, state.height);
	renderer.fillRect(575, 0, state.laneWidth, state.height);

	// where we're going we don't need roads
	renderer.setColor(200, 200, 200);
	foreach (car; state.cars) {
		renderer.fillRect(cast(int)car.x - car.w / 2,
		                  cast(int)car.y - car.h / 2,
		                  car.w, car.h);
	}

	renderer.present();
}
