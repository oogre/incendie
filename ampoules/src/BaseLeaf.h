#ifndef BaseLeaf_h
#define BaseLeaf_h

class BaseLeaf{
    public :
        virtual int begin(){ return false; };
        virtual bool update(){ return false; };
};

#endif // BaseLeaf_h