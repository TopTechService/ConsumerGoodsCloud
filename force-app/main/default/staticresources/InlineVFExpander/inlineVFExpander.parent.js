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
var inet_socket;
var inet_windowOnload = window.onload;

/*
 * We need to wait for onload event before starting easyXDM.Socket to ensure
 * there's no conflict with other salesforce functionality
 */
window.onload = function() {
	if (inet_windowOnload != null)
		inet_windowOnload();
		
	inet_socket = new easyXDM.Socket({
		remote: "https://c."+inet_getSFInstance()+".visual.force.com/apex/InlineVFExpander",
		swf: "https://c."+inet_getSFInstance()+".visual.force.com/resource/1301087741000/InlineVFExpander/easyxdm.swf",
		onMessage: function(message, origin){
			// retrieves list of VF page IDs and their new height
			if (typeof message != 'undefined' && message.indexOf('IVFE_frameIDsHeights=') !== -1)
			{
				var params = message.replace('IVFE_frameIDsHeights=','').split(';');
				var paramFrameHeights = new Array();
				var param, frameId, frameHeight;
				
				for (i=0;i<params.length;i++)
				{
					param = params[i].split(':');
					frameId = param[0];
					frameHeight = param[1];
					if (document.getElementById(frameId) != null)
						document.getElementById(frameId).style.height=frameHeight+'px';
				}
			// retrieves initial list of iframe IDs for load confirmation
			} else if (typeof message != 'undefined' && message.indexOf('IVFE_frameIDs=') !== -1) {
				var params = message.replace('IVFE_frameIDs=','').split(';');
				var frameID;
				
				for (i=0;i<params.length;i++)
				{
					frameID = params[i];
					if (frameID != "")
						inet_waitForFrameLoad(frameID,1);
				}
			}
		}
	});
};

/*
 * Wait for 3 seconds to see if iframe is loaded and pass its id
 * back to child iframe
 */
function inet_waitForFrameLoad(frameID,counter)
{
	if (document.getElementById(frameID) == null && counter < 15)
	{
		setTimeout(inet_waitForFrameLoad,200,frameID,(counter+1));
	}
	else if (document.getElementById(frameID) != null)
	{
		inet_socket.postMessage('IVFE_frameID='+frameID);
	}
}

/*
 * Get salesforce instance (na1, na2, emea, etc.)
 */
function inet_getSFInstance()
{
	var url = window.location.toString();
	var domain = url.match( /:\/\/([^\.]*)\./ ); 
	domain = domain[1]?domain[1]:''; 
	
	return domain;
}