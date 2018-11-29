;+
;;********************************************************************************
;*
;*  Author:
;*     name:  Colby Ham
;*     phone: (509)554-4076
;*     email: colby.ham@pnnl.gov
;*
;********************************************************************************
;** @file pblhtsonde.pro
;*  pblhtsonde VAP Main Functions.
;*
; *  Main entry function.
; *
;- 
pro pblhtsonde, type, _ref_extra=extra
    compile_opt idl2, logical_predicate

    ds=dsproc()
    ds.use_nc_extension

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
