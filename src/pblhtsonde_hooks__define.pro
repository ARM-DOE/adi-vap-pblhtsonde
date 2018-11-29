;+
;********************************************************************************
;
;  Author:
;     name:  Colby Ham
;     phone: (509)554-4076
;     email: colby.ham@pnnl.gov
;
;*******************************************************************************
;   @file pblhtsonde_hooks.pro
;   pblhtsonde VAP Hook Functions.
;
; A single object is used to handle all hooks in this example.
; Execution starts below the class definition function.
; Calling syntax:
;  IDL> .run test_hook_obj

;*  Initialize the process.
;*
;* This function is used to do any up front process initialization that
;* is specific to this process, and to create the UserData structure that
;* will be passed to all hook functions.
;*
;* If an error occurs in this function it will be appended to the log and
;* error mail messages, and the process status will be set appropriately.
;*
;*
;*
; *Init hook
;* @param ds {in}{required}{type=dsproc}
;*         Object reference to the dsproc system.
;* @returns
;*         1 to continue, 0 to abort further processing
;-
 
function pblhtsonde_hooks::init_process_hook, ds
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then print, '==== Inside init hook ===='

    ; Example, set userdata to the current process name
    ds.userdata = dsproc_get_name()

    ; Insert init process code here

    ; 1=continue, 0=abort.
    return, 1

end

;+
;*  Finish the process.
; 
;*  This function frees all memory used by the UserData structure.
;*  @param ds {in}{required}{type=dsproc}
;*          Object reference to the dsproc system.
;*  @returns
;*          The return value is ignored by the caller
;*
;-
function pblhtsonde_hooks::finish_process_hook, ds
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside finish hook ===='
        print, 'Userdata: ',ds.userdata
    endif

    ; Insert finish process code here

    return, 1
end

;+
;*  Hook function called just after data is retrieved.
;*
;*  This function will be called once per processing interval just after data
;*  retrieval, but before the retrieved observations are merged and QC is applied.
;*
;   @param ds {in}{required}{type=dsproc}
;           Object reference to the dsproc system.
;   @param interval {in}{required}{type=long64}
;           An array of long64 integers on the form: [ begin_time, end_time ]
;           Times are seconds since 1-Jan-1970.
;   @param ret_data {in}{required}{type=CDSGroup}
;           Object reference to the CDSGroup retrieved data.
;   @returns
; *    1 if processing should continue normally
; *    0 if processing should skip the current processing interval
; *         and continue on to the next one.
; *    -1 if a fatal error occurred and the process should exit.
;-
function pblhtsonde_hooks::post_retrieval_hook, ds, interval, ret_data
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside post-retrieval hook ===='
        print, 'Site: ',ds.site
        print, 'Facility: ',ds.facility
        print, 'Userdata: ',ds.userdata
        print, 'Begin time: ', systime(0, interval[0])
        print, 'End time: ', systime(0, interval[1])
        help, ret_data
    endif

    ; Insert post-retrieval code here

    ; output to text file if debug is > 1
;    if ds.debug gt 1 then begin
;        void = dsproc_dump_retrieved_datasets( $
;            './debug_dumps', 'post_retrieval.debug', 0)
;    endif

    ; 1=continue, 0=abort.
    return, 1
end


;+
;*  Main data processing function.
;*
;*  This function will be called once per processing interval just after the
;*  output datasets are created, but before they are stored to disk.
;*
;*  @param ds {in}{required}{type=dsproc}
;*          Object reference to the dsproc system.
;*  @param interval {in}{required}{type=long64}
;*          An array of long64 integers on the form: [ begin_time, end_time ]
;*          Times are seconds since 1-Jan-1970.
;*  @param input_data {in}{required}{type=CDSGroup}
;*          Object reference to the CDSGroup input data.
;*  @returns
;*          1 to continue, 
;*          -1 to abort further processing,
;*          0 to continue to next processing interval
;-
function pblhtsonde_hooks::process_data_hook, ds, interval, input_data
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside process data hook ===='
        print, 'Userdata: ',ds.userdata
        print, 'Begin time: ', systime(0, interval[0])
        print, 'End time: ', systime(0, interval[1])
    endif

    ; Insert process data code here

    ; output to text file if debug is > 1
    if ds.debug gt 1 then begin
        void = dsproc_dump_output_datasets( $
            './debug_dumps', 'process_data.debug', 0)
    endif

    ; 1=continue, 0=abort.
    return, 1
end

;+
; Class definition
;
; User defined member variables can be defined below
;-
pro pblhtsonde_hooks__define
  compile_opt idl2, logical_predicate
  s={ pblhtsonde_hooks $
    , Inherits IDL_Object $
    }
end
