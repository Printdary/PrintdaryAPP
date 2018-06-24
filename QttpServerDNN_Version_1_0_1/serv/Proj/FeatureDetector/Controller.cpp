#include "Controller.h"
#include <QDebug>
#include <QTimer>
#include <QtCore>
#include <QtConcurrent/QtConcurrent>

Controller::Controller(ParametrsForFeatureDetector params,int countOfThreads, QObject *parent): QObject(parent),m_params(params)
{
    //divideIntoParts(params.imagesFolder,countOfThreads);
    std::vector <cv::String> allPaths;
    cv::glob(params.imagesFolder,allPaths,true);
    QTimer* timer;
    timer = new QTimer();
    feThreads = new QThread[countOfThreads];
    controllers = new ObjectController();
    qDebug() << allPaths.size();
    FeatureDetector obj;
    obj.run(m_params,allPaths);
    //Feature
    //detectors = new FeatureDetector[countOfThreads];
    m_conf=-1;
    QFuture<void> *f1=new QFuture<void> [countOfThreads];

   // for(int i = 0 ; i < countOfThreads;++i){
    //    f1[i]=QtConcurrent::run(this, &Controller::onStartSlot);
   // }

   // for(int i = 0 ; i < countOfThreads;++i){
   //     f1[i].waitForFinished();
   // }


    //    QFuture<void> f1=QtConcurrent::run(this,&Controller::onStartSlot);
    //    QFuture<void> f2=QtConcurrent::run(this,&Controller::onStartSlot);

    //    f1.waitForFinished();
    //    f2.waitForFinished();
    //  timer->start(1000);
    //   timer->moveToThread(feThreads);
    //  connect(this,SIGNAL(startH()),this,SLOT(onStartSlot()));


    //   qDebug()<< "before for""''";
    //    for(int i =0; i<countOfThreads;++i){
    //        //QMetaObject::invokeMethod(feThreads+i,)
    //        //controllers[i].moveToThread(&feThreads[i]);

    //        connect(feThreads+i,SIGNAL(started()),this,SLOT(onStartSlot()),Qt::QueuedConnection);

    //        feThreads[i].start();
    //       // QMetaObject::invokeMethod(&controllers[i],"run",Qt::QueuedConnection,
    ////                                  Q_ARG(const ParametrsForFeatureDetector &,m_params),
    ////                                  Q_ARG(const std::vector < cv::String> &, m_paths.at(m_conf)));
    //        //controllers[i].m_detector->run(m_params,m_paths.at(m_conf));
    //       // m_conf++;
    //    }

    //    qDebug()<<"after for";

    //    //if(feThreads[i].isRunning()){

    //    //    feThreads[i].quit();
    //    //    qDebug()<<"Runing";
    //    //}
    //    //}
    m_fd.infoAboutThis(params);
    QCoreApplication::exit(0);

}

void Controller::divideIntoParts(const std::string & path , int countOfThreads)
{
    std::vector <cv::String> allPaths;
    cv::glob(path,allPaths,true);

    m_paths.resize(countOfThreads);
    int pos=0;
    int con= allPaths.size()/countOfThreads;
    for(int i =0 ; i< countOfThreads;++i){
        if(i==countOfThreads-1){
            con=allPaths.size()-pos;
        }
        std::vector <cv::String>::iterator itb=allPaths.begin()+pos;
        std::vector <cv::String>::iterator ite=allPaths.begin()+pos+con;
        std::vector <cv::String> newVec(itb,ite);
        m_paths.at(i)=newVec;
        pos+=con;
    }

}

void Controller::onStartSlot()
{

    m_conf++;
    FeatureDetector obj;
    qDebug()<<"Working thread N:"<<m_conf;
    obj.run(m_params,m_paths.at(m_conf));



}
