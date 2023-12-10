package sscript;

import haxe.Constraints;
import sscript.hscriptBase.*;
import sscript.hscriptBase.Expr;

import sys.FileSystem;
import sys.io.File;

import openfl.Assets;

/**
    A simple class for haxe scripts.

    For creating a new script without a file, look at this example.
    ```haxe
    var script:String = "package; private final num:Int = 1; function traceNum() { trace(num); }";
    var sscript:SScript = new SScript().doString(script);
    sscript.call('traceNum', []); // 1
    ```

    If you want to create a new script with a file, look at this example.
    ```haxe
    var script:String = "script.hx";
    var sscript:SScript = new SScript(script);
    sscript.call('traceNum', []);
    ```
**/
class SScript
{
    /**
        Map of the all created scripts.

        When you create a new script, it will be set in this map, `global`.
    **/
    public static var global(default, null):Map<String, SScript> = new Map();

    /**
        Use this to access to interpreter's variables!
    **/
    public var variables(get, never):Map<String, Dynamic>;

    /**
        Main interpreter and executer. 
    **/
    public var interp(default, null):Interp;

    /**
        An unique parser for the script to parse strings.
    **/
    public var parser:Parser;

    /**
        The script to execute. Gets set automatically if you create a `new` SScript.
    **/
    public var script(default, null):String = "";

    /**
        This variable tells if this script is active or not.

        Set this to false if you do not want your script to get executed!
    **/
    public var active:Bool = true;


    /**
        This string tells you the path of your script file as a read-only string.
    **/
    public var scriptFile(default, null):String = "";

    /**
        If true, enables error traces from the functions.
    **/
    public var traces:Bool = true;

    /**
        If true, enables private access to everything in this script. 
    **/
    public var privateAccess:Bool = true;

    /**
        Package path of this script. Gets set automatically when you use `package`.
    **/
    public var packagePath(default, null):String = "";

    /**
        Creates a new haxe script that will be ready to use after executing.

        @param scriptPath The script path or the script itself.
        @param Preset If true, Sscript will set some useful variables to interp. 
        @param startExecute If true, script will execute itself. If false, it will not execute
        and functions in the script file won't be set to interpreter. 
    **/
    public function new(?scriptPath:String = "", ?preset:Bool = true, ?startExecute:Bool = true)
    {
        if (scriptPath != ""  && scriptPath != null)
        {
            if (FileSystem.exists(scriptPath))
                script = File.getContent(scriptPath);
            else if (Assets.exists(scriptPath))
                script = Assets.getText(scriptPath);
            else
                script = scriptPath;

            scriptFile = scriptPath;
        }
        else 
        {
            scriptFile = SSId.unnullID();
        }

        global.set(scriptFile, this);

        interp = new Interp();
        interp.setScr(this);

        parser = new Parser();
        parser.script = this;
        @:privateAccess parser.setIntrp(interp);
        interp.setPsr(parser);

        if (preset)
            this.preset();

        if (startExecute && scriptPath != "")
            execute();
    }

    /**
        Executes this script once.

        If this script does not have any variables set, executing won't do anything.
    **/
    public function execute():Void
    {
        if (interp == null || !active)
            return;

        var expr:Expr = parser.parseString(script, scriptFile);
	    interp.execute(expr);
    }
    
    /**
        Sets a variable to this script. 
        
        If `key` already exists it will be replaced.
        
        If you want to set a variable to multiple scripts check the `setOnscripts` function.
        @param key Variable name.
        @param obj The object to set. 
        @return Returns this instance for chaining.
    **/
    public function set(key:String, obj:Dynamic):SScript
    {
        if (interp == null || !active)
        {
            if (traces)
            {
                if (interp == null) 
                    trace("This script is unusable!");
                else 
                    trace("This script is not active!");
            }

            return this;
        }

        interp.variables.set(key, obj);
        return this;
    }

    /**
        Unsets a variable from this script. 
        
        If a variable named `key` doesn't exist, unsetting won't do anything.
        @param key Variable name to unset.
        @return Returns this instance for chaining.
    **/
    public function unset(key:String):SScript
    {
        if (interp == null || !active || key == null || !interp.variables.exists(key))
            return this;

        interp.variables.remove(key);

        return this;
    }

    /**
        Gets a variable by name. 
        
        If a variable named as `key` does not exists return is null.
        @param key Variable name.
        @return The object got by name.
    **/
    public function get(key:String):Dynamic
    {
        if (interp == null || !active)
        {
            if (traces)
            {
                if (interp == null) 
                    trace("This script is unusable!");
                else 
                    trace("This script is not active!");
            }

            return null;
        }

        return if (exists(key)) interp.variables.get(key) else null;
    }

    /**
        Calls a function from the script file.

        `ATTENTION:` You MUST execute the script at least once to get the functions to script's interpreter.
        If you do not execute this script and `call` a function, script will ignore your call.
        
        @param func Function name in script file. 
        @param args Arguments for the `func`.
        @return Returns the return value in the function. If the function is `Void` returns null.
     **/
    public function call(func:String, args:Array<Dynamic>):Dynamic
    {
        if (func == null)
        {
            if (traces)
                trace('Function name cannot be null for $scriptFile!');
            return null;
        }

        if (args == null)
        {
            if (traces)
                trace('Arguments cannot be null for $scriptFile!');
            return null;
        }

        if (interp == null || !interp.variables.exists(func))
        { 
            if (traces)
            {
                if (interp == null) 
                    trace('Interpreter is null!');
                else 
                    trace('Function $func does not exist in $scriptFile.'); 
            }

            return null;
        }
   
        var functionField:Function = get(func);
        return Reflect.callMethod(this, functionField, args);
    }

    /**
        Clears all of the keys assigned to this script.

        @return Returns this instance for chaining.
    **/
    public function clear():SScript
    {
        if (interp == null)
            return this;

        var importantThings:Array<String> = ['true', 'false', 'null', 'trace'];

        for (i in interp.variables.keys())
            if (!importantThings.contains(i))
                interp.variables.remove(i);

        return this;
    }

    /**
        Tells if the `key` exists in this script's interpreter.
        @param key The string to look for.
        @return Return is true if `key` is found in interpreter.
    **/
    public function exists(key:String):Bool
    {
        if (interp == null)
            return false;

        return interp.variables.exists(key);
    }

    /**
        Triggers itself when the script fails to execute.
        Generally happens because of syntax errors.

        When triggered, calls the function named `errorThrow` (if exists) in the script.
        `errorThrow` must return `null` or nothing, if is not null it immediately stops itself from running
        and throws an exception.

        Always returns null and cannot be overriden.
    **/
    final public function error(err:sscript.hscriptBase.Expr.Error)
    {
        var oldTraces:String = '$traces';
        traces = false;
        var call:Dynamic = call('errorThrow', [err]);
        if (call != null)
            throw '"errorThrow" must return null or nothing.';
        traces = oldTraces == 'true' ? true : false;
        return call = null;
    }

    /**
        Tells if any of the keys in `keys` array exist in `interp`.

        If one key or more exist in `interp` returns true.
    @param keys Key array you want to check.
    **/
    public function anyExists(keys:Array<String>):Bool
    {
        if (interp == null)
            return false;

        for (key in keys)
            if (exists(key))
                return true;
            
        return false;
    }

    /**
        Tells if all of keys in `keys` array exist in `interp`.

        If one key or more do not exist in `interp`, it immediately breaks itself and returns false.
        @param keys Key array you want to check.
    **/
    public function allExists(keys:Array<String>):Bool
    {
        if (interp == null)
            return false;

        for (key in keys)
            if (!exists(key))
                return false;

        return true;
    }

    /**
        Sets some useful variables to interp to make easier using this script.
        Override this function to set your custom sets aswell.
    **/
    public function preset():Void
    {
        set('Math', Math);
        set('Std', Std);
        set('StringTools', StringTools);
        set('Sys', Sys);
        set('Date', Date);
        set('DateTools', DateTools);
        set('PI', Math.PI);
        set('POSITIVE_INFINITY', 1 / 0);
        set('NEGATIVE_INFINITY', -1 / 0);
        set('NaN', 0 / 0);
        set('File', File);
        set('FileSystem', FileSystem);
        set('this', this);
        set('SScript', SScript);
    }

    /**
        Executes a string once instead of a script file.

        This does not change your `script` and `scriptFile`.
        @param string String you want to execute.
        @return Returns this instance for chaining.
    **/
    public function doString(string:String):SScript
    {
        if (!active || interp == null)
            return this;

        var expr:Expr = parser.parseString(string);
        interp.execute(expr);

        return this;
    }

    /**
        Sets a variable in every SScript ever created.
    **/
    public static function setInGlobal(key:String, obj:Null<Dynamic>):Void
    {
        for (i in global)
        {
            i.set(key, obj);
        }
    }

    /**
        Sets a variable in multiple scripts.
        @param scriptArray The scripts you want to set the variable to.
        @param key Variable name.
        @param obj The object to set to `key`.
    **/
    public static function setMultiple(scriptArray:Array<SScript>, key:String, obj:Dynamic):Void
    {
        return for (script in scriptArray)
            script.set(key, obj);
    }

	function get_variables():Map<String, Dynamic> 
    {
		return interp.variables;
	}

    function setPackagePath(p):String
    {
        return packagePath = p;
    }
}
