import derelict.sdl2.mixer;

class State {
	int width = 1000;
	int height = 1000;

	bool running = true;

    Mix_Music* music;

	Guy[] cars;
	int laneWidth = 250;
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
