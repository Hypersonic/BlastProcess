import derelict.sdl2.mixer;
import derelict.sdl2.sdl;

class State {
	int width;
	int height;
	double FOV_Y = 90;

	bool running = true;

    Mix_Music* music;
	SDL_Window *window;
	SDL_GLContext context;

	ulong TICK_LEN = 30; // length of a tick (x msecs)
	ulong t = 0;

	int sceneIndex = 0;
	int numScenes = 0;
	void function(ref State)[] initFuncs;
	void function(ref State)[] updateFuncs;
	void function(ref State)[] renderFuncs;

	this(int w, int h) {
		width = w;
		height = h;
	}
};

bool nextScene(ref State state) {
	// if there's no next scene, return
	if (state.sceneIndex >= state.numScenes - 1) {
		state.sceneIndex  = state.numScenes - 1;
		return false;
	}

	state.initFuncs[++state.sceneIndex](state);
	return true;
}

class Guy {
	double x, y;
	double r, g, b;

	int w = 10;
	int h = 10;

	this(double x, double y, double r, double g, double b) {
		this.x = x;
		this.y = y;
		this.r = r;
		this.g = g;
		this.b = b;
	}
};
