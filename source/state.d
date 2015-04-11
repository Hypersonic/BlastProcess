import gfm.sdl2;

class State {
	int width = 1000;
	int height = 1000;

	bool running = true;
	SDL2 sdl2;
	SDL2Renderer renderer;

	Guy[] cars;
	int laneWidth = 250;
};

class Guy {
	double x, y;
	double r, g, b;

	this(double x, double y, double r, double g, double b) {
		this.x = x;
		this.y = y;
		this.r = r;
		this.g = g;
		this.b = b;
	}
};
