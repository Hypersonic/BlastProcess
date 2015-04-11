import std.math;
import std.random;
import std.conv;
import std.algorithm.comparison;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import state;
import render_util;

void init(ref State state) {
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

    // Increment t
	state.t++;
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
