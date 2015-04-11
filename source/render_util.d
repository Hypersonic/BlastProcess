import derelict.opengl3.gl;

void fillRect(int x, int y, int w, int h) {
	glBegin(GL_QUADS);
	glVertex3f(x - w/2, y - h/2, 0);
	glVertex3f(x + w/2, y - h/2, 0);
	glVertex3f(x + w/2, y + h/2, 0);
	glVertex3f(x - w/2, y + h/2, 0);
	glEnd();
}
