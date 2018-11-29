;+
;;********************************************************************************
;*
;*  Author:
;*     name:  
;*     phone: 
;*     email: 
;*
;********************************************************************************
;*
;*  REPOSITORY INFORMATION:
;*    $Revision: 1.2 $
;*    $Author: sivaraman $
;*    $Date: 2013-08-08 23:28:38 $
;*    $State: Exp $
;*
;********************************************************************************
;*
;*  NOTE: DOXYGEN is used to generate documentation for this file.
;*
;*******************************************************************************
;** @file pblhtsonde_vap.pro
;*  pblhtsonde VAP Main Functions.
;*
; *  Main entry function.
; *
;- 
pro pblhtsonde, type, _ref_extra=extra
    compile_opt idl2, logical_predicate

    ds=dsproc()
    ;ds.debug=n_elements(debug) ? debug : 2

    ; This can be an array or a scalar
    proc_names = [ 'pblhtsonde' ]

    ; Create an instance of the myhooks class
    handler=obj_new('pblhtsonde_hooks')

    ; define hooks to the handler object defined above
    ; the object class must have hook methods with
    ; predefined names correspnding to each name below
    ; followed by _hook.
    ; Defines which hooks should be routed to the handler object.
    ds.set_hook, 'init_process', handler
    ds.set_hook, 'finish_process', handler
    ds.set_hook, 'process_data', handler

    ds.set_hook, 'post_retrieval', handler

    ; run main
    ds.main, 'PM_RETRIEVER_VAP', $
        proc_version=__version__(), $
        proc_names = proc_names, $
        /reprocess, ARGV = command_line_args(), $
       _strict_extra=extra

    print, 'IDL command line args.'
    print, command_line_args()

    stat=ds.status

    obj_destroy, ds
    exit, status=stat

end
