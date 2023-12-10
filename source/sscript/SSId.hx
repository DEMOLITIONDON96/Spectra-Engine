package sscript;

class SSId
{
    public static var nullID(default, null):Int = 0;

    public static function unnullID() 
    {
        return '${nullID++}';
    }
}