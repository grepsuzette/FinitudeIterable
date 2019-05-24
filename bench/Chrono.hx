/**
 * Measure duration to the millisecond.
 *
 * Two modes:
 *  1) new Chrono("Quartermaster") will automatically issue a trace prefixed by {Chrono:Quartermaster} every time you stop(), lap(), ss() or startStop().
 *  2) new Chrono(false) will construct a silent chrono. You'll just rely on the Float returned by stop() and lap().
 **/
class Chrono {
	var _start:Float; 				// starting time
	var _name:String;				// name of the operation measured. @sa _c
	var _c:String;					// chrono name. Shown at the beginning of every trace.
	var _t:Bool;					// tracing enabled. True by default.

	var _pausedAt:Float;			// last moment pause() was called
	var _pausedAcc:Float;			// accumulated pause time
	var _isPaused:Bool;

	/**
	 * Build a new chrono.
	 * You have to start it manually.
	 * @param (name) It can be set later. Note: it has no use if you disable tracing.
	 * @param (tracing enabled) By default, chrono will call Tool.trace() to show the results. If setting t=false, it will disable tracing, and you only get the Float returns.
	 */
	public function new(?n:String="NoChronoName", t:Bool=true) {
		_c = n;
		_t = t;
		_start = 0;
		_pausedAcc = 0;
		_isPaused = false;
	}
	
	public function pause():Chrono {
		if (_isPaused) return this;
		_pausedAcc += now() - _start;
		_isPaused = true;
		return this;
	}
	
	public function unpause():Chrono {
		if (!_isPaused) throw "Chr952";
		_start = now();
		_isPaused = false;
		return this;
	}
	
	/**
	 * Restart chronometer, whether or not it was stopped, with a new name.
	 * Call stop() or lap() to stop it or read the elapsed time.
	 * @sa restartSame()
	 */
	public function start(n:String="noName"):Chrono {
		_name = n;
		_start = now();
		_pausedAcc = 0;
		_isPaused = false;
		return this;
	}

	/**
	 * Stops chronometer, autotraces the result with the name
	 * @param (suffix) Optionnal string, that will be added to the starting string. Usually used to add information unknown before starting the chrono, such as how many elements were processed.
	 * @return Time spent in ms.
	 **/
	public function stop(?s:String=""):Float {
		var r = lap(s);
		_start = 0;
		_pausedAcc = 0;
		_isPaused = false;
		return r;
	}
	
	/**	
	 * Stop chronometer and restart immediately with the same name
	 * @sa alias ss()
	 * @return Time spent in ms.
	 */
	public function stopStart(n:String):Float {
		var r = stop();
		start(n);
		return r;
	}
	
	/**
	 * This somewhat unpoetic name is an alias for stopStart().
	 */
	inline public function ss(n:String):Float { return stopStart(n); }

	/**
	 * Read current time and trace something, but let the chronometer run.
	 * @param suffix Optionnal string, that will be added to the starting string. Usually used to add information unknown before starting the chrono, such as how many elements were processed.
	 * @return Time spent in ms. 
	 **/
	public function lap(?suffix:String=""):Float {
		var mul = #if (flash || js) 1 #else 1000 #end;
		var r:Float = Std.int(mul * (_pausedAcc + (_isPaused ? 0 : now() - _start)));
		var t:String;
		
		if (_t && _start > 0) {
			t = _name + ": " + Std.int(mul * (_pausedAcc + ( _isPaused ? 0 : now() - _start))) + "ms" + (suffix.length>0 ? " [" + suffix + "]" : "");
			#if modelAvailable Log.warn("@" + _c + "@ " + t); #else trace("@" + _c + "@ " + t); #end
		}
		return r;
	}
	
	
	// obtain current time, with microseconds precision.
	inline public static function now():Float {
		#if neko return Sys.time();
		#else return Date.now().getTime(); #end
	}

}
