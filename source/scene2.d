import std.math;
import std.stdio;

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

double rot = 0;

void init(ref State state) {
	tetraVerts = genTetraVerts();
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
	rot += 0.03;
}

void render(ref State state) {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glRotatef(-20, 0, 0, 1);
	glRotatef(180 / PI * rot, 0, 1, 0);
	glTranslatef(0, -0.3, 0);
	glScalef(0.25, 0.25, 0.25);

	// render the tetrahedron
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
