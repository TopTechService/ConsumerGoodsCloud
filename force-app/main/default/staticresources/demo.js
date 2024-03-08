$(document).ready(function() {

    // Init Themeswitcher
    if (typeof($.fn.themeswitcher) !== 'undefined') {
        $('#themeswitcher').themeswitcher();
        $('.jquery-ui-themeswitcher-trigger', $('#themeswitcher')).addClass('ui-widget ui-corner-all');
    }

    // Set form and its elements
    $('form').each(function() {
        $(this).css({'display':'block'}).submit(function() { return false; });
    });
    $('textarea.syntax').css({ 'width':'100%', 'height':'100px', 'resize':'none' });

    $('.body-download ul li a').each(function() { $(this).after('&#160;&#160;<strong>'+$(this).text()+'</strong>'); $(this).button({'label':'Download', 'icons':{'primary': 'ui-icon-arrowthickstop-1-s'}}); });
    $('a.external').each(function() {
        $(this).attr('target','external');
        $(this).after('<span class="extlink" title="External Link: '+$(this).attr('href')+'"><span class="ui-icon ui-icon-extlink"></span></span>');
    });

    // get code:
    var getcode = function(a, b) {
        var c = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"\n    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">\n<head>\n    <!-- including jquery core -->\n    <link class="ui-theme" href="styles/jquery/jquery-ui-1.8.16.custom.css" rel="stylesheet" type="text/css" />\n    <script src="jscripts/jquery/jquery-1.6.2.min.js" type="text/javascript"></script>\n    <script src="jscripts/jquery/jquery-ui-1.8.16.custom.min.js" type="text/javascript"></script>\n    <!-- including jquery ui tinytbl -->\n    <link href="../jquery.ui.tinytbl.css" rel="stylesheet" type="text/css" />\n    <script src="../jquery.ui.tinytbl.js" type="text/javascript"></script>\n    <script type="text/javascript">\n    //<![CDATA[\n{__JSCODE__}\n    // ]]>\n    </script>\n</head>\n<body>\n{__HTMLCODE__}\n</body>\n</html>';
        if (!a) {
            a = '';
        }
        if (b) {
            if (typeof(b) == 'string') {
                b = ''+b;
            } else {
                var i = 'buildsourcecode', x = b.clone();
                $('body').append('<div id="'+i+'"></div>');
                x.appendTo('#'+i);
                b = $('#'+i).html();
                b = '    '+b;
                $('#'+i).empty().remove();
            }
        } else {
            b = '';
        }
        c = c.replace(/{__JSCODE__}/g, a);
        c = c.replace(/{__HTMLCODE__}/g, b);
        return c;
    }, showcode = function(a, b) {
        if (!(typeof(CodeMirror) !== 'undefined')) {
            return false;
        }
        a.each(function() {
            var  h, i = $(this).attr('id') || 0, j, n = $(this).attr('name') || 0, o, x = $(this).get(0), t = x.tagName || 0;
            if (!b) {
                b = 'javascript';
            }
            var cmo = { mode: b, gutter: true, fixedGutter: true, lineNumbers: true }, cmf = function(a) {
                var c = a.data('cm'), l = c.lineCount(), s = c.getScrollerElement() || 0;
                if (s) {
                    if (l > 10) {
                        $(s).css({'height':'166px'});
                    } else {
                        $(s).css({'height':'auto'});
                    }
                }
            };
            if (t && (''+t).toLowerCase() == 'textarea' && (n || i)) {
                if (n) {
                    o = n;
                } else if (i) {
                    o = i;
                }
                if (!$(this).data('cm')) {
                    $(this).data('cm', CodeMirror.fromTextArea(x, cmo));
                } else {
                    $(this).data('cm').setValue($(this).val());
                }
                cmf($(this));
                $(this).data('cm').refresh();
            } else {
                if (n) {
                    o = n;
                } else if (i) {
                    o = i;
                }
                if (!$(this).data('cm')) {
                    cmo.value = $(this).text();
                    $(this).data('cm', CodeMirror(function(z){ x.parentNode.replaceChild(z,x); }, cmo));
                } else {
                    $(this).data('cm').setValue($(this).text());
                }
                cmf($(this));
                $(this).data('cm').refresh();
            }
        });
    }, code2 = '    $(document).ready(function() {\n'
        + '        $(\'#table-1\').tinytbl({\n'
        + '            direction: \'ltr\'   // text-direction\n'
        + '            thead: true,       // fixed table thead\n'
        + '            tfoot: true,       // fixed table tfoot\n'
        + '            cols: 1,           // fixed number of columns (ltr)\n'
        + '            width: 700,        // table width\n'
        + '            height: 200        // table height\n'
        + '        });\n'
        + '    });';
    code2 = getcode(code2, $('#table-2'));
    $('#example-2-codetext').val(code2);
    showcode($('#example-2-codetext'), 'htmlmixed');
    showcode($('pre.syntax'), 'htmlmixed');

    $('#code-2show').css({'display':'none'});

    // Functions for the demo
    var i = l = 0, t1 = '#table-1', t2 = '#table-2', rn = rm = $('tr', $(t1)).size(), rf = $('tr', $(t1 + ' tbody')).first();
    var b1 = 'button[name="', b2 = ['create','destroy','append','remove'], b3 = '"]', bf = {
        code: function(a) {
            var x = '#example-1';
            $(x+'-codetext').val('');
            $(x+'-codetext').val(a);
            if ($(x+'-codetext').val()!=='') {
                $(x+'-code').css({'display':'block'});
                showcode($(x+'-codetext'));
                $(x+'-form').css({'padding-bottom':'0px'});
            } else {
                $(x+'-code').css({'display':'none'});
                $(x+'-form').css('padding-bottom');
            }
        },
        create: function() {
            // Check params for sample #2
            var f = h = false, c = (parseInt($('#setcol').val(), 10) || 0), d = 'ltr';
            if ($('#setth:checked').size() > 0) { h = true; }
            if ($('#settf:checked').size() > 0) { f = true; }
            if ($('#setdir:checked').size() > 0) { d = 'rtl'; }
            if (!c && !f && !h) { return false; }
            // Init sample #1
            $(t1).tinytbl({
                direction: d,
                thead: h,
                tfoot: f,
                cols: c,
                width: 'auto',
                height: 'auto'
            });
            $(t1).tinytbl('focus');
            bf.code('// init tinytable\n$(\''+t1+'\').tinytbl({\n    direction: \''+d+'\'\n    thead: '+h+',\n    tfoot: '+f+',\n    cols: '+c+',\n    width: \'auto\',\n    height: \'auto\'\n});\n// set focus to tinytable\n$(\''+t1+'\').tinytbl(\'focus\');');
            // Button and form changes
            bf.change(true);
            $(b1+b2[3]+b3).button({'disabled':true});
        },
        destroy: function() {
            // Destroy sample #2
            $(t1).tinytbl('destroy');
            bf.change(false);
            bf.code('// destroy tinytable\n$(\''+t1+'\').tinytbl(\'destroy\');');
        },
        append: function() {
            var a = $('th,td', rf), b = a.length, c = 0, h = '', tb = '<td>', te = '<\u002Ftd>';
            rn++;
            for (c = 0; c < b; c++) {
                tb = '<td>'; te = '<\u002Ftd>';
                if ((''+a[c].tagName).toLowerCase() !== 'td') {
                    tb = '<th>'; te = '<\u002Fth>';
                }
                h+=tb+'row '+rn+' - cell '+(c+1)+te;
            }
            h = '<tr class="row-added row-'+rn+'">'+h+'<\u002Ftr>';
            // Append new row to sample #2
            $(t1).tinytbl('append', $(h));
            bf.code('// add a new row at the buttom of the table:\n$(\''+t1+'\').tinytbl(\'append\', $(\''+h+'\'));\n\n// add a new row at the top of the table\n$(\''+t1+'\').tinytbl(\'prepend\', $(\''+h+'\'));');
            $(b1+b2[3]+b3).button({'disabled':false});
        },
        remove: function() {
            // Remove last appended row from sample #2
            if (rn <= 0) {
                return false;
            }
            $(t1).tinytbl('remove', $('tr.row-'+rn));
            bf.code('// remove a row from table:\n$(\''+t2+'\').tinytbl(\'remove\', $(\'tr.row-'+rn+'\'));');
            rn = (rn-1);
            if (rn <= rm) {
                $(b1+b2[3]+b3).button({'disabled':true});
            }
        },
        change: function(v) {
            var i = 0, l = b2.length, d1 = {'display':'block'}, d2 = {'display':'none'}, f1 = '#table-1f1', f2 = '#table-1f2';
            $(f1).css(d1);
            $(f2).css(d1);
            if (!v) {
                for (i = 0; i < l; i++) {
                    $(b1+b2[i]+b3).button({'disabled':true});
                }
                $(b1+b2[0]+b3).button({'disabled':false});
                $(f1).css(d1);
                $(f2).css(d2);
            } else {
                for (i = 0; i < l; i++) {
                    $(b1+b2[i]+b3).button({'disabled':false});
                }
                $(b1+b2[0]+b3).button({'disabled':true});
                $(f1).css(d2);
                $(f2).css(d1);
            }
        }
    };

    // Init buttons and forms for sample #1
    for (i = 0; i < b2.length; i++) {
        $(b1+b2[i]+b3).click(function() { bf[$(this).attr('name')](); });
    }
    bf.change(false);
    bf.code('');

    // Init sample #2
    if ($(t2).size() > 0) {
        $(t2).tinytbl({direction:'ltr', thead:true, tfoot:true, cols:1, width:700, height:200});
    }

    t3 = $('#example-3');
    // Init sample 3
    if (t3) {
        t3.tabs();
        $('table', t3).tinytbl({direction:'ltr', thead:true, tfoot:true, cols:1, width:'auto', height:200, renderer: true });
    }

    // Scrolling
    try {
        var c = 'body-menu-fix', m = $('.body-menu').first(), t = m.offset().top, w = window, h = (w.location.href || 0), s = function(){ if($(w).scrollTop()>t){m.addClass(c);}else{m.removeClass(c);} };
        $(window).scroll(function() { s(); });
        h = ( (h && (''+h).lastIndexOf('#') !== -1) ? (''+h).substring((''+h).lastIndexOf('#'), h.length) : 0 );
        if (h) {
            $(w).scrollTop($(h).offset().top);
            s();
        }
        $('a[href^="#"]', m).each(function() { $(this).click(function() { $(w).scrollTop($(h).offset().top); s(); }); });
    
        if ($('#gplusholder').size() > 0) {
            // $('#gplusholder').html('| <span class="gplus"><script type="text/javascript" src="https://apis.google.com/js/plusone.js">\n{lang: \'de\'}\n</script><g:plusone size="small"></g:plusone></span>');
        }
        
   } catch (e) {
        
   }
});