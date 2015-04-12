import std.math;
import std.stdio;
import std.algorithm;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import state;
import render_util;

double[] tetraVerts;
int[] tetraTriPtrs = [
	3, 1, 0,
	3, 0, 2,
	3, 2, 1,
	0, 1, 2
];

double tetraRot = 0;

double[] rainbow = [
	0, 0
];
const double NUM_RB_SEGS = 60;
const double RB_HEIGHT = 100;
const double RB_AMPL = 100;
const double SEG_W = 1000. / NUM_RB_SEGS;

const double TOTAL_ANGLE = PI;
double theta = TOTAL_ANGLE;

void init(ref State state) {
	tetraVerts = genTetraVerts();

	foreach (i; 0..NUM_RB_SEGS) {
		rainbow ~= RB_AMPL * sin(i / NUM_RB_SEGS * TOTAL_ANGLE);
	}
}

double[] genTetraVerts() {
	auto sqrt3 = sqrt(3.);
	auto invSqrt3 = 1 / sqrt(3.);

	return [
	 	 0,              0, sqrt3 - invSqrt3,
		-1,              0,        -invSqrt3,
	 	 1,              0,        -invSqrt3,
	 	 0, 2 * sqrt(2/3.),                0, 
	];
}

void update(ref State state) {
	tetraRot += 0.03;

	if (rainbow.length > 0) {
		rainbow = rainbow.remove(0);
		rainbow ~= RB_AMPL * sin(theta);
		theta += TOTAL_ANGLE / NUM_RB_SEGS;
	}
}

void render(ref State state) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_MODELVIEW);

	// render the rainbow trail
	glLoadIdentity();
	glTranslatef(0, -0.2, 0);
	glScalef(1./state.width, 1./state.height, 1);

	for (int i = 0; i < rainbow.length; i++) {
    	glColor3f(1.0, 0.0, 0.0);
    	fillRectTl(-1000 + i * SEG_W - 100, rainbow[i] - RB_HEIGHT * 1.5,
    	           SEG_W, RB_HEIGHT);

    	glColor3f(0.0, 1.0, 0.0);
    	fillRectTl(-1000 + i * SEG_W - 100, rainbow[i] - RB_HEIGHT * 0.5,
    	           SEG_W, RB_HEIGHT);

    	glColor3f(0.0, 0.0, 1.0);
    	fillRectTl(-1000 + i * SEG_W - 100, rainbow[i] - RB_HEIGHT * -0.5,
    	           SEG_W, RB_HEIGHT);
	}

	// render the tetrahedron
	glLoadIdentity();
	glTranslatef(0, 0.001 * rainbow[$ - 1], 0);
	glRotatef(-20, 0, 0, 1);
	glRotatef(180 / PI * tetraRot, 0, 1, 0);
	glTranslatef(0, -0.3, 0);
	glScalef(0.25, 0.25, 0.25);

    glLineWidth(10.0);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glColor3f(1, 0, 0);
	glBegin(GL_TRIANGLES);
	foreach (tri; 0..4) {
		foreach (vert; 0..3) {
			glVertex3dv(tetraVerts.ptr + 3*tetraTriPtrs[tri * 3 + vert]);
		}
	}
	glEnd();

	SDL_GL_SwapWindow(state.window);
}
