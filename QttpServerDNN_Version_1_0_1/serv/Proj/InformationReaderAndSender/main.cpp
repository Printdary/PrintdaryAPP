#include <QCoreApplication>
#include "InformationReaderAndSender.h"
#include <QString>
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);


     InformationReaderAndSender* obj = new InformationReaderAndSender;
     obj->run((argc == 1)?"":argv[1]);

     return a.exec();
}
