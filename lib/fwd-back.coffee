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
      # Initialize the cursor position 'history' for our package
      editor.fwdBackHistory =
        cursorPositions: [editor.getCursorBufferPosition()],
        current: 0
      # Listen for cursor position change
      editor.onDidChangeCursorPosition (event) ->
        console.log(event)

  deactivate: ->
    @subscriptions.dispose()

  fwd: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.insertText('You pressed the fwd button.')

  back: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.insertText('You pressed the back button.')
