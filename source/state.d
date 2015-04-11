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

	Guy[] cars;
	int laneWidth = 250;

	this(int w, int h) {
		width = w;
		height = h;
	}
};

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
