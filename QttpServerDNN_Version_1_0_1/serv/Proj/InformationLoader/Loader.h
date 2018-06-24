#ifndef LOADER_H
#define LOADER_H

#include <iostream>

//#include "ClusteringInforProvider.h"
//#include "FindImage.h"
#include "Compare.h"
#include "InfoProvider.h"
#include <QString>
#include <QDebug>
class Loader
{
public:
    Loader();
    bool loadFile(QString name);
    std::vector<std::string> searchImage(QString name, QString ClustName);
    bool updateFiles(QString name);
    std::vector<std::string> similarImgs(QString path, QString ClustName);
    std::vector <QString> getInfo();

//private:
//    cv::String PathConfig(std::string path);
private:
    std::vector <InfoProvider> m_loades;
    std::vector < QString> m_names;
    std::string m_foundedImg;

};

#endif // LOADER_H
