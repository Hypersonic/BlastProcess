import derelict.opengl3.gl;

void fillRect(int x, int y, int w, int h) {
	glBegin(GL_QUADS);
	glVertex3f(x - w/2, y - h/2, 0);
	glVertex3f(x + w/2, y - h/2, 0);
	glVertex3f(x + w/2, y + h/2, 0);
	glVertex3f(x - w/2, y + h/2, 0);
	glEnd();
}

void fillRectTl(double x, double y, double w, double h) {
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

	glBegin(GL_QUADS);
	glVertex3f(x, y, 0);
	glVertex3f(x + w, y, 0);
	glVertex3f(x + w, y + h, 0);
	glVertex3f(x, y + h, 0);
	glEnd();
}
