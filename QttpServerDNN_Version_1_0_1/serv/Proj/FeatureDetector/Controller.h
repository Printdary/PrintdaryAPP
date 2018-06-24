#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include "Parameters.h"
#include "FeatureDetector.h"

class ObjectController :public QObject
{
    Q_OBJECT
public:
    ObjectController(QObject* obj = NULL):
        QObject(obj),
        m_detector(new FeatureDetector())
    {

    }
public slots:
    void run(const ParametrsForFeatureDetector &Params,const std::vector<cv::String> & vec)
    {
        m_detector->run(Params,vec);
    }
public:
    FeatureDetector* m_detector;

};


class Controller : public QObject
{
    Q_OBJECT
    QThread* feThreads;
    //FeatureDetector* detectors;
    ObjectController* controllers;
public:
    explicit Controller(ParametrsForFeatureDetector params, int countOfThreads, QObject *parent = 0);
public:
    void onStartSlot();
signals:
    void startH();
private:

    void divideIntoParts(const std::string & path , int countOfThreads);
private :
    FeatureDetector m_fd;
    std::vector < std::vector <cv::String> > m_paths;
    ParametrsForFeatureDetector m_params;
    int m_conf;
};

#endif // CONTROLLER_H
