import std.math;
import std.stdio;
import std.random;
import std.c.stdlib;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;
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
}

bool init(ref State state) {
    DerelictSDL2.load();
    DerelictSDL2Mixer.load();

    // Audio initialization 
    if (Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 2048 ) < 0) {
        writefln( "SDL_mixer could not initialize! SDL_mixer Error: %s", Mix_GetError() );
        return true;
    }
    state.music = Mix_LoadMUS("res/dragster-5k-047.mp3");

    if (!state.music) {
        writefln("Mix_LoadMUS(\"res/dragster-5k-047.mp3\"): %s", Mix_GetError());
        return true;
    }

    Mix_PlayMusic(state.music, 10);

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
	// moven de cars arong rodd
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

	// rotten da tings
	state.rotVal += 0.0003;
}

void render(ref State state) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// set perspective transform
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//gluPerspective(state.FOV_Y, 1. * state.width / state.height, 0.1, 100);

	// set modelview transform
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glRotatef(180 * PI * state.rotVal, 1, 0, 0);
	glTranslatef(-1, 1, 0);
	glScalef(2. / state.width, -2. / state.height, 1);

	// roads ???
	glColor3f(0.3, 0.3, 0.3);
	fillRect(300, 500, state.laneWidth, state.height);
	fillRect(700, 500, state.laneWidth, state.height);

	// where we're going we don't need roads
	glColor3f(0.75, 0.75, 0.75);
	foreach (car; state.cars) {
		fillRect(cast(int)car.x, cast(int)car.y, car.w, car.h);
	}

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
