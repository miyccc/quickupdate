#include "lua_myunzip_auto.hpp"
#include "MyUnZip.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "LuaScriptHandlerMgr.h"
#include "CCLuaValue.h"



int lua_myunzip_MyUnZip_unregisterUnZipFinishHandler(lua_State* tolua_S)
{
    int argc = 0;
    MyUnZip* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MyUnZip",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MyUnZip*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myunzip_MyUnZip_unregisterUnZipFinishHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_myunzip_MyUnZip_unregisterUnZipFinishHandler'", nullptr);
            return 0;
        }
        cobj->unregisterUnZipFinishHandler();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MyUnZip:unregisterUnZipFinishHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_myunzip_MyUnZip_unregisterUnZipFinishHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_myunzip_MyUnZip_registerUnZipFinishHandler(lua_State* tolua_S)
{
    int argc = 0;
    MyUnZip* cobj = nullptr;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MyUnZip",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MyUnZip*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myunzip_MyUnZip_registerUnZipFinishHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
#if COCOS2D_DEBUG >= 1
        if(!toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err))
            goto tolua_lerror;
#endif
        LUA_FUNCTION handler = ( toluafix_ref_function(tolua_S,2,0));
//        ScriptHandlerMgr::getInstance()->addObjectHandler((void*)cobj, handler, ScriptHandlerMgr::HandlerType::EVENT_CUSTOM_BEGAN);
        cobj->registerUnZipFinishHandler(handler);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MyUnZip:registerUnZipFinishHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_myunzip_MyUnZip_registerUnZipFinishHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_myunzip_MyUnZip_UnZipFile(lua_State* tolua_S)
{
    int argc = 0;
    MyUnZip* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MyUnZip",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MyUnZip*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myunzip_MyUnZip_UnZipFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        const char* arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "MyUnZip:UnZipFile"); arg0 = arg0_tmp.c_str();

        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "MyUnZip:UnZipFile"); arg1 = arg1_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_myunzip_MyUnZip_UnZipFile'", nullptr);
            return 0;
        }
        bool ret = cobj->UnZipFile(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MyUnZip:UnZipFile",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_myunzip_MyUnZip_UnZipFile'.",&tolua_err);
#endif

    return 0;
}
int lua_myunzip_MyUnZip_onUnZipFinish(lua_State* tolua_S)
{
    int argc = 0;
    MyUnZip* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"MyUnZip",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (MyUnZip*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_myunzip_MyUnZip_onUnZipFinish'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_myunzip_MyUnZip_onUnZipFinish'", nullptr);
            return 0;
        }
        cobj->onUnZipFinish();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "MyUnZip:onUnZipFinish",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_myunzip_MyUnZip_onUnZipFinish'.",&tolua_err);
#endif

    return 0;
}
int lua_myunzip_MyUnZip_getInstance(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"MyUnZip",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_myunzip_MyUnZip_getInstance'", nullptr);
            return 0;
        }
        MyUnZip* ret = MyUnZip::getInstance();
        object_to_luaval<MyUnZip>(tolua_S, "MyUnZip",(MyUnZip*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "MyUnZip:getInstance",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_myunzip_MyUnZip_getInstance'.",&tolua_err);
#endif
    return 0;
}
static int lua_myunzip_MyUnZip_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MyUnZip)");
    return 0;
}

int lua_register_myunzip_MyUnZip(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"MyUnZip");
    tolua_cclass(tolua_S,"MyUnZip","MyUnZip","",nullptr);

    tolua_beginmodule(tolua_S,"MyUnZip");
        tolua_function(tolua_S,"unregisterUnZipFinishHandler",lua_myunzip_MyUnZip_unregisterUnZipFinishHandler);
        tolua_function(tolua_S,"registerUnZipFinishHandler",lua_myunzip_MyUnZip_registerUnZipFinishHandler);
        tolua_function(tolua_S,"UnZipFile",lua_myunzip_MyUnZip_UnZipFile);
        tolua_function(tolua_S,"onUnZipFinish",lua_myunzip_MyUnZip_onUnZipFinish);
        tolua_function(tolua_S,"getInstance", lua_myunzip_MyUnZip_getInstance);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(MyUnZip).name();
    g_luaType[typeName] = "MyUnZip";
    g_typeCast["MyUnZip"] = "MyUnZip";
    return 1;
}

TOLUA_API int register_all_myunzip(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,nullptr,0);
	tolua_beginmodule(tolua_S,nullptr);

	lua_register_myunzip_MyUnZip(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

