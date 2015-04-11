import std.stdio;
import std.random;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

import state;

void main()
{
	State state = new State;
	init(state);

	// state loop
	while (state.running) {

		checkKeys(state);
		update(state);
		render(state);
	}

	// ciao!
	writeln("quitting; goodbye");
}

void checkKeys(ref State state) {
}

void init(ref State state) {
    DerelictSDL2.load();
    DerelictSDL2Mixer.load();

    // Audio initialization 
    if (Mix_OpenAudio( 44100, MIX_DEFAULT_FORMAT, 2, 2048 ) < 0) {
        writefln( "SDL_mixer could not initialize! SDL_mixer Error: %s", Mix_GetError() );
    }
    state.music = Mix_LoadMUS("res/dragster-5k-047.mp3");

    if (!state.music) {
        writefln("Mix_LoadMUS(\"res/dragster-5k-047.mp3\"): %s", Mix_GetError());
    }

    Mix_PlayMusic(state.music, 10);

	// populate left lane
	for (int i = 0; i < 40; i++) {
		int lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(175 + (1/12. + lane / 6.) * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
	}

	// populate right lane
	for (int i = 0; i < 40; i++) {
		int lane = cast(int)(uniform01() * 6);
		state.cars ~= new Guy(575 + (1/12. + lane / 6.) * state.laneWidth,
		                      uniform01() * state.height, 1, 1, 1);
	}
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
}
