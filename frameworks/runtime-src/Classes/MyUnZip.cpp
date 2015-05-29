//
//  UnZip.cpp
//  update
//
//  Created by BinWu on 15/5/28.
//
//
#ifdef MINIZIP_FROM_SYSTEM
#include <minizip/unzip.h>
#else // from our embedded sources
#include "unzip/unzip.h"
#endif

#include "cocos2d.h"
#include "MyUnZip.h"

#include "base/ZipUtils.h"

#include <zlib.h>
#include <assert.h>
#include <stdlib.h>

#include "base/CCData.h"
#include "base/ccMacros.h"
#include "platform/CCFileUtils.h"
#include "CCLuaEngine.h"
#include <map>


USING_NS_CC;

MyUnZip::MyUnZip()
{
    m_UnZipFinishHandler = 0;
}

MyUnZip::~MyUnZip()
{
    
}

static MyUnZip *m_unzip = 0;

MyUnZip* MyUnZip::getInstance()
{
    if (m_unzip == NULL)
    {
        m_unzip = new MyUnZip();
    }
    return m_unzip;
}

void MyUnZip::registerUnZipFinishHandler(int handler)
{
    unregisterUnZipFinishHandler();
    m_UnZipFinishHandler = handler;
}

void MyUnZip::unregisterUnZipFinishHandler()
{
    if(m_UnZipFinishHandler)
    {
        LuaEngine::getInstance()->removeScriptHandler(m_UnZipFinishHandler);
        m_UnZipFinishHandler = 0;
    }
}

void MyUnZip::onUnZipFinish()
{
    if(m_UnZipFinishHandler)
    {
        LuaEngine::getInstance()->executeEvent(m_UnZipFinishHandler, "state");
    }
}

bool MyUnZip::UnZipFile(const char* filename, const char* destPath)
{
    if (filename == NULL || destPath == NULL)
    {
        CCLOG("source zip is null or dest path is null!");
        return false;
    }
    
    // Open the zip file
    std::string outFileName = filename;
    unzFile zipfile = unzOpen(outFileName.c_str());
    if (!zipfile)
    {
        CCLOG("can not open downloaded zip file %s", outFileName.c_str());
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", outFileName.c_str());
        unzClose(zipfile);
        return false;
    }
    
    const int BUFFER_SIZE = 8192;
    const int MAX_FILENAME = 512;
    // Buffer to hold data read from the zip file
    char readBuffer[BUFFER_SIZE];
    
    CCLOG("start uncompressing");
    
    // Loop to extract all files.
    uLong i;
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  NULL,
                                  0,
                                  NULL,
                                  0) != UNZ_OK)
        {
            CCLOG("can not read file info");
            unzClose(zipfile);
            return false;
        }
        
        std::string storagePath = destPath;
        std::string fullPath = storagePath + fileName;
        
        // Check if this entry is a directory or a file.
        const size_t filenameLength = strlen(fileName);
        if (fileName[filenameLength - 1] == '/')
        {
            // get all dir
            std::string fileNameStr = std::string(fileName);
            size_t position = 0;
            while ((position = fileNameStr.find_first_of("/", position)) != std::string::npos)
            {
                std::string dirPath = storagePath + fileNameStr.substr(0, position);
                // Entry is a direcotry, so create it.
                // If the directory exists, it will failed scilently.
                if (!FileUtils::getInstance()->createDirectory(dirPath.c_str()))
                {
                    CCLOG("can not create directory %s", dirPath.c_str());
                    //unzClose(zipfile);
                    //return false;
                }
                position++;
            }
        }
        else
        {
            // Entry is a file, so extract it.
            
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not open file %s", fileName);
                unzClose(zipfile);
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(fullPath.c_str(), "wb");
            if (!out)
            {
                CCLOG("can not open destination file %s", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("can not read zip file %s, error code is %d", fileName, error);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while (error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i + 1) < global_info.number_entry)
        {
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not read next file");
                unzClose(zipfile);
                return false;
            }
        }
    }
    unzClose(zipfile);
    onUnZipFinish();
    
    return true;
}
