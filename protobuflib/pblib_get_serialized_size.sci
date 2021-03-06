exec pblib_encoded_field_size.sci
exec pblib_encoded_tag_size.sci

function [msg_size] = pblib_get_serialized_size(msg)
//pblib_get_serialized_size 
//   function [msg_size] = pblib_get_serialized_size(msg)
//
//   Estimates the size a message will take when serialized.
// 
//   Will go through a message and estimate serialized sizes of valid fields.
//   Estimates generally include tag size plus encoded field size.
//
//   See also pblib_generic_serialize_to_string, pblib_write_wire_type
  
//   protobuf-matlab - FarSounder's Protocol Buffer support for Matlab
//   Copyright (c) 2008, FarSounder Inc.  All rights reserved.
//   http://code.google.com/p/protobuf-matlab/
//  
//   Redistribution and use in source and binary forms, with or without
//   modification, are permitted provided that the following conditions are met:
//  
//       * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
//  
//       * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
//  
//       * Neither the name of the FarSounder Inc. nor the names of its
//   contributors may be used to endorse or promote products derived from this
//   software without specific prior written permission.
//  
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//   POSSIBILITY OF SUCH DAMAGE.

//   Author: fedor.labounko@gmail.com (Fedor Labounko)
//   Support function used by Protobuf compiler generated .m files.


  LABEL_REPEATED = 3;
  WIRE_TYPE_LENGTH_DELIMITED = 2;
  msg_size = 0;
  descriptor = msg.descriptor_function();
  for i=1:length(descriptor.fields)
    field = descriptor.fields(i);
    if (get(msg.has_field, field.name) == 0 || isempty(msg.(field.name)))
      continue;
    end

    if (field.options.packed)
      tag_length = pblib_encoded_tag_size(...
          field.number, WIRE_TYPE_LENGTH_DELIMITED);
    else
      tag_length = pblib_encoded_tag_size(...
          field.number, field.wire_type);
    end

    // need this extra if to make sure repeated strings/bytes are done correctly
    if (field.label == LABEL_REPEATED)
      msg_size = msg_size + tag_length + ...
          (1 - field.options.packed) * ...
          (length(msg.(field.name)) - 1) * tag_length;
    else
      msg_size = msg_size + tag_length;
    end
    msg_size = msg_size + pblib_encoded_field_size(msg.(field.name), field);
  end

  // Now add the space required by the stored unknown fields
  for i=1:length(msg.unknown_fields)
    msg_size = msg_size + length(msg.unknown_fields(i).raw_data);
  end

endfunction
