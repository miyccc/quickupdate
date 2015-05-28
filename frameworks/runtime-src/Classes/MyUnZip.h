//
//  UnZip.h
//  update
//
//  Created by BinWu on 15/5/28.
//
//

#ifndef __update__MyUnZip__
#define __update__MyUnZip__

class MyUnZip{
public:
    static MyUnZip* getInstance();
    bool UnZipFile(const char* filename, const char* destPath);
private:
    MyUnZip();
    ~MyUnZip();
};

#endif /* defined(__update__MyUnZip__) */
