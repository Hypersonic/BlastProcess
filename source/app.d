import std.stdio;
import std.random;
import std.c.stdlib;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import state;
import render_util;

void main()
{
	writeln();
	writeln("preparing to init");

	State state = new State(1000, 1000);
	if (!init(state)) {
		cleanup(state);
		exit(-1);
	}

	writeln("good init broskis");

	// state loop
	while (state.running) {
		// process inputs
		SDL_Event e;
		while (SDL_PollEvent(&e)) {
			switch (e.type) {
				case SDL_KEYDOWN:
					keyboard(state, e, true);
					break;
				case SDL_QUIT:
					state.running = false;
					break;
				default:
					break;
			}
		}

		checkKeys(state);
		update(state);
		render(state);
	}

	cleanup(state);

	// ciao!
	writeln("quitting; goodbye");
}

void checkKeys(ref State state) {
	/* TODO
	if (state.sdl2.keyboard().isPressed(SDLK_q))
		state.running = false;
	*/
}

bool init(ref State state) {
	// init sdl2, opengl
	DerelictSDL2.load();
	DerelictGL.load();

	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		writeln("error initalizing sdl");
		return false;
	}

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	state.window = SDL_CreateWindow("Blast Process",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		state.width, state.height,
		SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS);
	if (!state.window) {
		writeln("window couldn't create");
		return false;
	}

	state.context = SDL_GL_CreateContext(state.window);
	SDL_GL_SetSwapInterval(1);

	glClearColor(0, 0, 0, 0);
	glViewport(0, 0, state.width, state.height);

	DerelictGL.reload();

	// populate left lane
	for (int i = 0; i < 40; i++) {
		int lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(175 + (1 + lane) / 7. * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
	}

	// populate right lane
	for (int i = 0; i < 40; i++) {
		int lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(575 + (1 + lane) / 7. * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
	}

	return true;
}

void update(ref State state) {
	foreach (i,car; state.cars) {
		if (i < state.cars.length / 2) {
			car.y += 0.4;
			if (car.y > state.height + car.h / 2)
				car.y = -car.h / 2;
		} else {
			car.y -= 0.4;
			if (car.y < -car.h / 2)
				car.y = state.height + car.h / 2;
		}
	}
}

void render(ref State state) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// set modelview transform
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	//glTranslatef(-state.width / 2, - state.height / 2, 0);
	glScalef(2. / state.width, 2. / state.height, 1);
	glTranslatef(-state.width / 2, -state.height / 2, 0);

	// roads ???
	glColor3f(0.3, 0.3, 0.3);
	fillRect(300, 500, state.laneWidth, state.height);
	fillRect(700, 500, state.laneWidth, state.height);

	// where we're going we don't need roads
	glColor3f(0.75, 0.75, 0.75);
	foreach (car; state.cars) {
		fillRect(cast(int)car.x, cast(int)car.y, car.w, car.h);
	}

	fillRect(0, 0, 10, 10);
	fillRect(state.width, 0, 10, 10);
	fillRect(state.width, state.height, 10, 10);
	fillRect(state.width, state.height, 10, 10);

	// TODO show to screen
	SDL_GL_SwapWindow(state.window);
}

void keyboard(ref State state, ref SDL_Event e, bool keydown) {
	switch (e.key.keysym.sym) {
		case SDLK_q:
			state.running = false;
			break;
		default:
			break;
	}
}

void cleanup(ref State state) {
	SDL_GL_DeleteContext(state.context);
	SDL_DestroyWindow(state.window);
	SDL_Quit();
}
