/*
 *  This is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This software is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _BCD_EMUL_HH_
#define _BCD_EMUL_HH_

#include <iosfwd>
#include <cstdint>

struct Context {
	uint8_t X:1;
	uint8_t N:1;
	uint8_t Z:1;
	uint8_t V:1;
	uint8_t C:1;
	Context(uint8_t _X, uint8_t _Z);
	bool operator==(const Context& other) const;
	bool operator!=(const Context& other) const;
	void write(std::ostream& out) const;
};

std::ostream& operator<<(std::ostream& out, const Context& ctx);

uint8_t abcd(Context& ctx, uint8_t xx, uint8_t yy);
uint8_t sbcd(Context& ctx, uint8_t xx, uint8_t yy);
uint8_t nbcd(Context& ctx, uint8_t xx);

#endif //_BCD_EMUL_HH_

