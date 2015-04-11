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
import scene1;
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

    Mix_PlayMusic(state.music, 10);

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

auto clamp(T, U, V)(T val, U lower, V upper) {
    if (val < lower) return lower;
    if (val >= upper) return upper;
    return val;
}

<<<<<<< HEAD
=======
void render(ref State state) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// set perspective transform
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//gluPerspective(state.FOV_Y, 1. * state.width / state.height, 0.1, 100);

	// set modelview transform
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    auto first_angle = clamp(180 / PI * (state.t * (PI/3300)), 0, 30);
    glRotatef(first_angle/4, 0, 0, 1);
    glRotatef(first_angle, 1, 0, 0);
    glRotatef(90, 0, 0, 1);
    glRotatef(90, 0, 1, 0);
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

    if (state.t > 600 && state.t % state.TICK_LEN / 2 == 0) {
        state.rainbowRoad ~= [uniform(0, state.width),
                              uniform(0, state.height)];
    }
    
    if (state.rainbowRoad.length > 1) {
        glLineWidth(10.0);
        import std.range;
        glBegin(GL_LINES); {
            foreach (first, second; lockstep(state.rainbowRoad[0 .. $-1], state.rainbowRoad[1 .. $])) {
                glColor3f(1.0, 0.0, 0.0);
                glVertex3f(first[0].to!float, first[1].to!float - 10, 0f);
                glVertex3f(second[0].to!float, second[1].to!float - 10, 0f);

                glColor3f(0.0, 1.0, 0.0);
                glVertex3f(first[0].to!float, first[1].to!float, 0f);
                glVertex3f(second[0].to!float, second[1].to!float, 0f);

                glColor3f(0.0, 0.0, 1.0);
                glVertex3f(first[0].to!float, first[1].to!float + 10, 0f);
                glVertex3f(second[0].to!float, second[1].to!float + 10, 0f);
            }
        } glEnd();
    }

	SDL_GL_SwapWindow(state.window);
}

>>>>>>> Rainbow road first pass
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
