#include <QtCore/QDebug>
#include <QtCore/QCoreApplication>

int main(int argc, char** argv)
{
	QCoreApplication app(argc, argv);
	int x;
	qDebug() << x;
	return app.exec();
}

