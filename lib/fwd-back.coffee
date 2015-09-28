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
        # ignore events triggered by the fwd or back commands
        if event.newBufferPosition isnt fb.current
          fb.back.push fb.current
          fb.current = event.newBufferPosition
          # we are adding a new point and not moving either forward or back
          # within the current history, so fwd should be "overwritten" to
          # preserve the new history state
          fb.fwd = [] if fb.fwd.length

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
