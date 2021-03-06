/*
 * shared_id.h
 *
 *  Created on: May 21, 2014
 *      Author: Julian Kranz
 */

#pragma once

#include "id.h"
#include <string>

namespace gdsl {
namespace rreil {

enum shared_id_type {
  TYPE_FLOATING_FLAGS
};

std::string shared_id_type_to_string(shared_id_type t);

class shared_id : public id {
private:
  shared_id_type inner;

  void put(std::ostream &out);
public:
  shared_id(shared_id_type _id);

  shared_id_type get_inner() {
    return inner;
  }

  bool operator== (id &other);

  std::string to_string();
  void accept(id_visitor &v);
};

}
}
