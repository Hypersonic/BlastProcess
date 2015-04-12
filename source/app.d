import std.conv;
import std.math;
import std.stdio;
import std.datetime;
import std.c.stdlib;
import core.thread;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;
import derelict.opengl3.gl;

import state;
static import scene1;
static import scene2;
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

	nextScene(state);
	writeln("good init broskis");
	StopWatch sw;

    // start music to avoid random offsets
    Mix_PlayMusic(state.music, 10);

	// state loop
	while (state.running) {
		sw.reset();
		sw.start();
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

		state.updateFuncs[state.sceneIndex](state);
		state.renderFuncs[state.sceneIndex](state);

		state.t++;
		sw.stop();

		auto len = sw.peek().length;
		if (len < state.TICK_LEN)
			Thread.sleep(dur!("msecs")(state.TICK_LEN - sw.peek().length));
	}

	cleanup(state);

	// ciao!
	writeln("quitting; goodbye");
}

bool init(ref State state) {
	if (!initAudio(state)) return false;
	if (!initVisual(state)) return false;

	state.initFuncs ~= &scene1.init;
	state.updateFuncs ~= &scene1.update;
	state.renderFuncs ~= &scene1.render;
	state.numScenes++;

	state.initFuncs ~= &scene2.init;
	state.updateFuncs ~= &scene2.update;
	state.renderFuncs ~= &scene2.render;
	state.numScenes++;

	return true;
}

bool initAudio(ref State state) {
    DerelictSDL2.load();
    DerelictSDL2Mixer.load();

    // Audio initialization 
    if (Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 2048 ) < 0) {
        writefln( "SDL_mixer could not initialize! SDL_mixer Error: %s", Mix_GetError() );
        return false;
    }
    state.music = Mix_LoadMUS("res/dragster-5k-047.mp3");

    if (!state.music) {
        writefln("Mix_LoadMUS(\"res/dragster-5k-047.mp3\"): %s", Mix_GetError());
        return false;
    }

    return true;
}

bool initVisual(ref State state) {
	// init sdl2, opengl
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

	return true;
}

bool nextScene(ref State state) {
	// if there's no next scene, return
	if (state.sceneIndex >= state.numScenes - 1) {
		state.sceneIndex  = state.numScenes - 1;
		return false;
	}

	state.initFuncs[++state.sceneIndex](state);
	return true;
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
