/**
 * Inline VisualForce Expander
 * http://www.inetindustry.com/
 * Copyright(c) 2011, Dmitri Sennikov, dmitri@inetindustry.com.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
	var inet_prev_paramFrameHeights = "";
	var inet_frameIDs = new Array();
	var inet_started = false;
	var inet_socket;
  
  	
	/*
	 * We need to wait for onload event before starting easyXDM.Socket to ensure
	 * there's no conflict with other salesforce functionality
	 */
    var inet_windowOnload = window.onload;
    window.onload = function() {
        if (inet_windowOnload != null)
            inet_windowOnload();
        inet_socket = new easyXDM.Socket({
        		swf: "/resource/1301087741000/InlineVFExpander/easyxdm.swf",
        		// upon confirmation from parent window, we can start working
        		// with other VF iframes
                onMessage: function(message,origin) {
                    if (typeof message != 'undefined' && message.indexOf('IVFE_frameID=') !== -1)
                    {
                        inet_frameIDs[inet_frameIDs.length] = message.replace('IVFE_frameID=','');
                        if (!inet_started)
                            inet_getFrameHeights();
                    }
                },
                // send initial list of VF pages for confirmation from
                // parent window
                onReady: function() {
                    inet_socket.postMessage("IVFE_frameIDs="+inet_getFrameIDs());
                }
            });
    }
  
  /*
   * Assuming VF pages don't have a namespace, we can access them
   * from parent window to get their changing document height
   */
  function inet_getFrameHeights()
  {
      inet_started = true;
      var paramFrameHeights = "";
      
      for (i=0;i<inet_frameIDs.length;i++)
      {
          if (window.top.frames[inet_frameIDs[i]] != null
                  && window.top.frames[inet_frameIDs[i]].document != null
                  && window.top.frames[inet_frameIDs[i]].document.readyState == 'complete')
              paramFrameHeights += inet_frameIDs[i]+':'+window.top.frames[inet_frameIDs[i]].document.body.offsetHeight+';';
      }
      
      // send message to parent window only if there's a change in document height
      if (paramFrameHeights != "" 
      		&& inet_prev_paramFrameHeights != paramFrameHeights)
      {
          inet_prev_paramFrameHeights = paramFrameHeights;
          inet_socket.postMessage("IVFE_frameIDsHeights="+paramFrameHeights);
      }
      setTimeout(inet_getFrameHeights,100);
  }
  