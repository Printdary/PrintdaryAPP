/****************************************************************************
** Meta object code from reading C++ file 'InformationReaderAndSender.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.10.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../InformationReaderAndSender/InformationReaderAndSender.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'InformationReaderAndSender.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.10.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_InformationReaderAndSender_t {
    QByteArrayData data[6];
    char stringdata0[91];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_InformationReaderAndSender_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_InformationReaderAndSender_t qt_meta_stringdata_InformationReaderAndSender = {
    {
QT_MOC_LITERAL(0, 0, 26), // "InformationReaderAndSender"
QT_MOC_LITERAL(1, 27, 15), // "sendInformation"
QT_MOC_LITERAL(2, 43, 0), // ""
QT_MOC_LITERAL(3, 44, 15), // "onReadyReadSlot"
QT_MOC_LITERAL(4, 60, 18), // "onDisconnectedSlot"
QT_MOC_LITERAL(5, 79, 11) // "deleteLater"

    },
    "InformationReaderAndSender\0sendInformation\0"
    "\0onReadyReadSlot\0onDisconnectedSlot\0"
    "deleteLater"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_InformationReaderAndSender[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   34,    2, 0x0a /* Public */,
       3,    0,   35,    2, 0x0a /* Public */,
       4,    0,   36,    2, 0x0a /* Public */,
       5,    0,   37,    2, 0x0a /* Public */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void InformationReaderAndSender::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        InformationReaderAndSender *_t = static_cast<InformationReaderAndSender *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->sendInformation(); break;
        case 1: _t->onReadyReadSlot(); break;
        case 2: _t->onDisconnectedSlot(); break;
        case 3: _t->deleteLater(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

QT_INIT_METAOBJECT const QMetaObject InformationReaderAndSender::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_InformationReaderAndSender.data,
      qt_meta_data_InformationReaderAndSender,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *InformationReaderAndSender::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *InformationReaderAndSender::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_InformationReaderAndSender.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int InformationReaderAndSender::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 4;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
