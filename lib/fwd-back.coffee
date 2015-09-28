{CompositeDisposable} = require 'atom'

module.exports = FwdBack =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands to move cursor to next/previous position
    @subscriptions.add atom.commands.add 'atom-workspace', 'fwd-back:fwd': => @fwd()
    @subscriptions.add atom.commands.add 'atom-workspace', 'fwd-back:back': => @back()

    atom.workspace.observeTextEditors (editor) ->
      editor.fwdback =
        back: [],
        current: editor.getCursorBufferPosition(),
        fwd: []
      editor.onDidChangeCursorPosition (event) ->
        fb = editor.fwdback
        if event.newBufferPosition isnt fb.current # ignore events triggered by
                                                   # the fwd or back commands
          fb.back.push fb.current
          fb.current = event.newBufferPosition

  deactivate: ->
    @subscriptions.dispose()

  fwd: ->
    if editor = atom.workspace.getActiveTextEditor()
      fb = editor.fwdback
      if fb.fwd.length
        fb.back.push fb.current
        fb.current = fb.fwd.pop()
        editor.setCursorBufferPosition fb.current

  back: ->
    if editor = atom.workspace.getActiveTextEditor()
      fb = editor.fwdback
      if fb.back.length
        fb.fwd.push fb.current
        fb.current = fb.back.pop()
        editor.setCursorBufferPosition fb.current
