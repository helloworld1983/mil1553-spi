/* MIL-STD-1553 <-> SPI bridge
 * Copyright(c) 2016 Stanislav Zhelnio
 * Licensed under the MIT license (MIT)
 * https://github.com/zhelnio/mil1553-spi
 */

`include "settings.sv"

`ifndef HELPMIL_INCLUDE
`define HELPMIL_INCLUDE

function string milType(input milStd1553::WordType t);
	import milStd1553::*;

	if(t == WSERV)		return "WSERV";
	if(t == WDATA)		return "WDATA";
	if(t == WDATAERR)	return "WDATAERR";
	return "WSERVERR";
endfunction

interface IPushMilHelper(input logic clk, IPushMil.master push);

    task automatic doPush(input milStd1553::WordType	t, logic [15:0] data);
		  @(posedge clk)	push.request <= '1; push.data.dataType	= t; push.data.dataWord = data;
		  @(posedge clk)	push.request <= '0;
		
		  @(push.done);
		  $display("IPushMilHelper %m <-- %s %h", milType(push.data.dataType), push.data.dataWord);	
	  endtask
	  
endinterface

interface IPopMilHelper(input logic clk, IPopMil.master pop);
  
    task automatic doPop();
		  @(posedge clk)	pop.request <= '1;
		  @(posedge clk)	pop.request <= '0;
		
		  @(pop.done);
		  $display("IPopMilHelper %m --> %s %h", milType(pop.data.dataType), pop.data.dataWord);	
	  endtask
  
endinterface

module DebugMilTransmitter(	input bit nRst, clk,
							IPushMil.slave push,
							IMilStd mil);	
	import milStd1553::*;
							   
	IPushMil rpush();
	IMilControl control();
	milTransceiver tr(nRst, clk, rpush, push, mil, control);

	always_ff @ (posedge clk) begin
		if(rpush.request) begin
			$display("DebugMilTransmitter %m --> %s %h", milType(rpush.data.dataType), rpush.data.dataWord);
			rpush.done <= '1;
		end

		if(rpush.done)
			rpush.done <= '0;
	end

endmodule

`endif 

